From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH 2.5.72] (1/3) PPPoE cleanup [TRIVIAL]
Date: Mon, 23 Jun 2003 01:59:46 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306230157140.578-100000@excalibur.intercode.com.au>
References: <20030620173139.01f935c7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
   Michal Ostrowski <mostrows@styx.uwaterloo.ca>, <netdev@oss.sgi.com>,
   <mostrows@speakeasy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030620173139.01f935c7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Jun 2003, Stephen Hemminger wrote:

> This is a cleanup patch, no change in functionality.
>   - Get rid of debug macro's that aren't used anywhere in the code.

I'm guessing that Michal wants to leave these in for future debugging?


- James
-- 
James Morris
<jmorris@intercode.com.au>
