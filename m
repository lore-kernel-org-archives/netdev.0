From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4/2.6] ipvs: improve conn rehashing, other fixes
Date: Mon, 22 Mar 2004 18:36:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040322183641.68ecb8a3.davem@redhat.com>
References: <20040321230703.408d2240.davem@redhat.com>
	<Pine.LNX.4.44.0403230036130.3318-600000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0403230036130.3318-600000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Mar 2004 00:58:38 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> Dave, please check the attached patches. There are three patches for 2.4, 
> and two for 2.6.

I am going to apply everything except the ip_vs_ctl.c change as
Julian has tol me under seperate cover that the locking he adds
there is not really necessary.

Thanks.
