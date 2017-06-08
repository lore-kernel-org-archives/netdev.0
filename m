From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the
 wireless-drivers-next tree
Date: Thu, 8 Jun 2017 22:47:25 +1000
Message-ID: <20170608224725.6cd98500@canb.auug.org.au>
References: <20170608122759.7ffda0c3@canb.auug.org.au>
        <3594bd0d-e2b4-a380-ba06-8dedbbcbe11f@quantenna.com>
        <20170608125737.1e09c36d@canb.auug.org.au>
        <87lgp24ra3.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>,
        Wireless <linux-wireless@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Dmitrii Lebed <dlebed@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Bindu Therthala <btherthala@quantenna.com>,
        Huizhao Wang <hwang@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <87lgp24ra3.fsf@codeaurora.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

On Thu, 08 Jun 2017 15:07:00 +0300 Kalle Valo <kvalo@codeaurora.org> wrote:
>
> Stephen Rothwell <sfr@canb.auug.org.au> writes:
> 
> > On Wed, 7 Jun 2017 19:43:18 -0700 Igor Mitsyanko <igor.mitsyanko.os@quantenna.com> wrote:  
> >>
> >> thanks. As I understand, you've applied this patch during a merge and no 
> >> further actions are required, correct?  
> >
> > Dave Miller will need to apply that patch (or something similar) when
> > he merges the wireless-drivers-next tree into the net-next tree.  I
> > will keep applying the patch each day until then.  
> 
> Thanks, I'll remind Dave about this when i submit the pull request (very
> soon now).

It occurred to me just after I wrote the previous message that it would
only be true after he merges the current net tree into the net-next tree.

-- 
Cheers,
Stephen Rothwell
