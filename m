From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Netfilter Kconfig:  Expose IPv4/6 connection tracking
 options by selecting NF_CONNTRACK
Date: Wed, 25 Jul 2007 02:46:28 +0200
Message-ID: <46A69D64.5060505@trash.net>
References: <200707240836.33494.a1426z@gawab.com> <200707242205.07545.a1426z@gawab.com> <46A65061.8010000@trash.net> <200707242301.42329.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Al Boldi <a1426z@gawab.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <200707242301.42329.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Patrick McHardy wrote:
> 
>>Al Boldi wrote:
>>
>>>Also, we could leave this as is, and select NF_CONNTRACK_ENABLED instead
>>>of NF_CONNTRACK.
>>
>>I guess so, and that would have to select NF_CONNTRACK.
> 
> 
> Should I resend, or can you take care of it?


Please resend after testing.
