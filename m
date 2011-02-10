From: "Bruce Rogers" <brogers@novell.com>
Subject: Re: [PATCH] virtio-net: add schedule check to napi_enable call
	in refill_work
Date: Wed, 09 Feb 2011 19:44:17 -0700
Message-ID: <4D52EE9102000048000A9BA4@novprvoes0310.provo.novell.com>
References: <132885.30568.qm@web110313.mail.gq1.yahoo.com>
	<201102101201.19656.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: <virtualization@lists.linux-foundation.org>,
        "Rusty Russell" <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <201102101201.19656.rusty@rustcorp.com.au>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

 >>> On 2/9/2011 at 06:31 PM, Rusty Russell <rusty@rustcorp.com.au> wrote: 
> On Thu, 10 Feb 2011 06:59:25 am Ken Stailey wrote:
>> Justification:
>> 
>> Impact: Under heavy network I/O load virtio-net driver crashes making VM 
> guest unusable.
> 
> Hmm, this went badly wrong.  I acked this patch, and it was mailed to
> netdev six months ago.
> 
> Bruce's patch used spaces instead of tabs, but that should not have caused
> it to be dropped.  I've taken that and ported it forwards, will repost now.
> 
> Thanks for picking this up off the floor!
> Rusty.

Thanks for taking care of that!

Bruce
