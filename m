From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] cache align qdisc data
Date: Wed, 4 Aug 2004 09:51:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804095153.3bd696a3.davem@redhat.com>
References: <410FAE42.2050909@trash.net>
	<20040803083820.711c917c@dell_ss3.pdx.osdl.net>
	<410FE4DD.5000306@trash.net>
	<20040803133139.43107fd3@dell_ss3.pdx.osdl.net>
	<410FF8C4.7010705@trash.net>
	<20040803140538.7c40f961@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803140538.7c40f961@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 14:05:38 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Ugh, here it is without the hfsc messup.

Stephen, I'll apply this after Patrick's qdisc_list
patch 'q_idx' issue is better understood so I can
apply that first.
