From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Mon, 15 Mar 2004 22:29:35 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040315212935.GB20830@wotan.suse.de>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net> <1079160064.11606.15.camel@viivi> <20040315092018.1e843d83@dell_ss3.pdx.osdl.net> <20040315132214.4d9b5347.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, pasi.sarolahti@iki.fi,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040315132214.4d9b5347.davem@redhat.com>
List-Id: netdev.vger.kernel.org

> Also, as Yoshfuji stated, you absolutely cannot change the existing
> sysctl numbers as tools that use the sysctl() system call use those
> numbers explicitly thus they are compiled into applications.

Actually it is fine these days. Numerical sysctl is deprecated
and should be removed soon.

-Andi
