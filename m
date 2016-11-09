From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
Date: Wed, 9 Nov 2016 13:29:27 -0800
Message-ID: <CAKgT0UdyKnERu5Vv8F2gw1XvFD4VczP5_C3nYZoC6=zcysjb3A@mail.gmail.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com> <20161109212341.GC12670@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        linux-mm <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109212341.GC12670@char.us.oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 9, 2016 at 1:23 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Wed, Nov 09, 2016 at 10:19:57AM -0500, Alexander Duyck wrote:
>> This patch series is a subset of the patches originally submitted with the
>> above patch title.  Specifically all of these patches relate to the
>> swiotlb.
>>
>> I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
>> currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
>> no updates are required for the previous set then this patch set can be
>> ignored since most of the changes are just cosmetic.
>
> I already had tested v2 so if you have patches that you want to put on top
> of that please do send them.

I will rebase and if anything looks like it needs to be urgently fixed
I'll resubmit.

Thanks.

- Alex
