From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: Re: linux-next: build failure after merge of the rdma tree
Date: Wed, 15 Feb 2017 10:39:44 +0530
Message-ID: <CA+sbYW3GyZ1cf9NfdJTF6Pn-XcMW2cKMVxSycsnp62N-r0Pi9g@mail.gmail.com>
References: <20170215113003.4c730d86@canb.auug.org.au> <ad8c1dc5-9d96-b45f-fe89-115ea4d0174c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <ad8c1dc5-9d96-b45f-fe89-115ea4d0174c@redhat.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 6:35 AM, Doug Ledford <dledford@redhat.com> wrote:
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Wed, 15 Feb 2017 11:23:25 +1100
>> Subject: [PATCH] RDMA/bnxt_re: fix for "bnxt_en: Update to firmware interface spec 1.7.0."
>>
>> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>
> Thanks Stephen.  I had been forewarned about this by Selvin and I
> instructed him to send me a fixup patch that would resolve the issue.  I
> would apply it to my tree before merging with Linus.  He just hadn't
> time to send it yet.  Your patch is sufficient as well, so I may just
> pull it in.  Thanks again.

Thanks Stephen and Doug for taking care of this.

Acked-by: Selvin Xavier <selvin.xavier@broadcom.com>
