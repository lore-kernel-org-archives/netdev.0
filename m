From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: Action repeat
Date: Wed, 04 May 2005 14:15:24 +0200
Message-ID: <4278BCDC.8010208@trash.net>
References: <4273BBAA.6060405@trash.net>	 <1114882045.8929.123.camel@localhost.localdomain>	 <4273CAB7.6080403@trash.net>	 <1114890709.8929.147.camel@localhost.localdomain>	 <20050430200848.GF577@postel.suug.ch>	 <1114894202.8929.165.camel@localhost.localdomain>	 <20050430215550.GH577@postel.suug.ch>	 <1114900485.8929.171.camel@localhost.localdomain>	 <20050430235809.GI577@postel.suug.ch>	 <1115035838.8929.236.camel@localhost.localdomain>	 <20050502150632.GM577@postel.suug.ch> <1115207194.7665.109.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115207194.7665.109.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Patrick, either you or i could do it. It doesnt matter if at the moment
> the structure only contains tcf_result or elements of tcf_result because
> i will add more to it later. Then we could kill access to tc_classid in
> exec()

I'll do it, I have a few patches touching this code lying around anyway

Regards
Patrick
