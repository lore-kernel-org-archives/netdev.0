From: Andi Kleen <ak@suse.de>
Subject: Re: network lockup with latest BK (LLTX?)
Date: Tue, 14 Sep 2004 18:41:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914164114.GF7397@wotan.suse.de>
References: <20040914142447.GA5615@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20040914142447.GA5615@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 12:24:47AM +1000, Anton Blanchard wrote:
> 
> Hi,
> 
> I have a machine with a number of e1000 adapters in it. It locked up
> while I was bringing up the network interfaces. I have attached
> backtraces of all relevant cpus.

See the patch I posted yesterday to netdev.

-Andi
