From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/4) propgate bridge internal MTU changes
Date: Thu, 29 Jul 2004 14:51:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729145128.35791769.davem@redhat.com>
References: <20040728153725.7ace281c@dell_ss3.pdx.osdl.net>
	<20040728191724.4afacdce.davem@redhat.com>
	<20040729105931.25815479@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040729105931.25815479@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 Jul 2004 10:59:31 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Follow up to earlier RCU patch.  Since now using RCU, need to use
> deferred free.  

All bridge patches applied, thanks Stephen.
