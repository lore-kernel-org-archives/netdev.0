From: Andi Kleen <ak@suse.de>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Thu, 22 May 2003 10:02:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522080232.GE15275@wotan.suse.de>
References: <20030513210541.GA4415@suse.de> <20030513.163150.28800008.davem@redhat.com> <20030514083236.GD8290@Wotan.suse.de> <20030514.121806.41651014.davem@redhat.com> <20030514192117.GA31303@Wotan.suse.de> <20030522005258.GC13028@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@redhat.com>, olh@suse.de,
   marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <20030522005258.GC13028@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Ah if we could just use a unnamed struct... 8)

Don't worry. Sometime someone will find a gcc 2.95 bug that prevents
compilation of some new kernel code and is too hard to work around. Once
that happens everybody will move to 3.2+ for the kernel (I don't think
3.0 is used anymore) 

-Andi
