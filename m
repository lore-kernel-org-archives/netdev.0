From: Andi Kleen <ak@suse.de>
Subject: Re: zero window probes on linux (fwd)
Date: Tue, 13 Apr 2004 20:50:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413205035.447c925c.ak@suse.de>
References: <200404131013.PAA18883@shilpa.india.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, praveen@shilpa.india.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Praveen Kumar Amritaluru <praveen@india.hp.com>
In-Reply-To: <200404131013.PAA18883@shilpa.india.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:43:29 +0530 (IST)
Praveen Kumar Amritaluru <praveen@india.hp.com> wrote:


> 
> 	This  seems  to be a bug.  Has it been  already  fixed in  later
> 	kernel versions or is this how it is intended to remain?

iirc this was intentional. The RFC suggested method doesn't work when talking to 
some stacks.

-Andi
