From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tun driver use private linked list.
Date: Sat, 9 Aug 2003 01:18:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809011801.3258f7af.davem@redhat.com>
References: <200308051630.28552.bellucda@tiscali.it>
	<20030805090647.691daa7e.shemminger@osdl.org>
	<200308051910.55823.bellucda@tiscali.it>
	<20030807154524.4794ad45.shemminger@osdl.org>
	<20030807155901.49f1a424.davem@redhat.com>
	<20030808113404.0e9e1e6d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030808113404.0e9e1e6d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Aug 2003 11:34:04 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Less grotty version, applies over earlier patch.
> 	- keep a private list.  
> 	- fix debug format strings.
> 	- drop the name entry in the private data structure since it already
> 	  has a pointer to netdev that has name.

Applied, thanks for following up on this Stephen.
