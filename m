From: Andi Kleen <ak@suse.de>
Subject: Re: Request for an ARPHRD_
Date: Tue, 25 Oct 2005 00:24:55 +0200
Message-ID: <200510250024.56088.ak@suse.de>
References: <200510240255.28416.daniele@orlandi.com> <200510241807.23290.ak@suse.de> <200510242333.05366.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Orlandi <daniele@orlandi.com>
In-Reply-To: <200510242333.05366.daniele@orlandi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 24 October 2005 23:33, Daniele Orlandi wrote:

> 
> > Normally Linux doesn't pre-allocate ABIs for out of tree code, mostly
> > because it is not guaranteed that the interface won't change there.
> 
> Could you clarify? What interface do you fear that could change?

Any interface implemented by your out of tree code for which you're
requesting to reserve constants.

-Andi
