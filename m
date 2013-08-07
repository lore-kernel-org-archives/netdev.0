From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 4/5] net: syncookies: export
 cookie_v6_init_sequence/cookie_v6_check
Date: Wed, 7 Aug 2013 22:27:58 +0200
Message-ID: <20130807222758.310fee47@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-5-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1375897371-18430-5-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  7 Aug 2013 19:42:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Extract the local TCP stack independant parts of
> tcp_v6_init_sequence() and cookie_v6_check() and export them for use
> by the upcoming IPv6 SYNPROXY target.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
