From: Nuno Ferreira <nuno.ferreira@graycell.biz>
Subject: Re: 2.6.9-rc2-mm2 fn_hash_insert oops
Date: Thu, 23 Sep 2004 22:38:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095975485.4339.1.camel@taz.graycell.biz>
References: <E1CARaS-00071j-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CARaS-00071j-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Qui, 2004-09-23 at 21:16 +1000, Herbert Xu wrote:
> Lukas Hejtmanek <xhejtman@mail.muni.cz> wrote:
> > 
> > However there is still the issue with endless loop in fn_hash_delete :(
> 
> Same problem, same fix.  Can someone think of a generic fix to
> list_for_each_*?
> 

This also fixed the problem I reported earlier with the machine freezing
when my Speedtouch USB ADSL modem connected.

Thanks
