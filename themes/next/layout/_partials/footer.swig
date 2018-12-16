<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love"><i class="fa fa-{{ theme.authoricon }}"></i></span>
  <span class="author" itemprop="copyrightHolder"><a href="https://github.com/MuYunyun">{{ config.author }}</a></span>
  <span class="with-love"><i class="fa fa-globe"></i></span>
  <span class="author" itemprop="copyrightHolder"><a href="http://www.miitbeian.gov.cn/">浙ICP备18050494号</a></span>
</div>

{% if theme.copyright %}
<div class="powered-by">
  {{ __('footer.powered', '<a class="theme-link" href="https://hexo.io">Hexo</a>') }}
</div>

<div class="theme-info">
  {{ __('footer.theme') }} -
  <a class="theme-link" href="https://github.com/iissnan/hexo-theme-next">
    NexT.{{ theme.scheme }}
  </a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <span id="busuanzi_container_site_pv">
  <i class="fa fa-user" aria-hidden="true"></i>
  <span id="busuanzi_value_site_pv"></span>
  </span>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <span id="busuanzi_container_site_uv">
  <i class="fa fa-eye" aria-hidden="true"></i>
  <span id="busuanzi_value_site_uv"></span>
  </span>
</div>
{% endif %}
