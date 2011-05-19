From: Greg KH <greg@kroah.com>
Subject: Re: [stable submission] vmxnet3: Fix inconsistent LRO
 state after initialization
Date: Wed, 18 May 2011 17:27:58 -0700
Message-ID: <20110519002758.GE8697@kroah.com>
References: <4DD2536E.1000008@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DD2536E.1000008@intra2net.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 12:52:30PM +0200, Thomas Jarosch wrote:
> Hi greg k-h,
> 
> please include commit ebde6f8acba92abfc203585198a54f47e83e2cd0
> "vmxnet3: Fix inconsistent LRO state after initialization"
> 
> in 2.6.37 / 2.6.38 stable.
> 
> 
> Kernel 2.6.32 first included the vmxnet3 driver and I've checked
> that the patch applies to 2.6.32.40 and 2.6.35.13, so it might be
> worth to include it in all maintained kernels.

Now queued up.

thanks,

greg k-h

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
