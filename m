From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [PATCH v2 00/10] Constify attribute_group structures
Date: Wed, 26 Jul 2017 12:05:16 +0530
Message-ID: <9af8fd47-ca11-1308-d526-e08eb7998d85@gmail.com>
References: <1499758370-24871-1-git-send-email-arvind.yadav.cs@gmail.com>
 <87fudkiskz.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fudkiskz.fsf@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,


On Tuesday 25 July 2017 06:25 PM, Kalle Valo wrote:
> Arvind Yadav <arvind.yadav.cs@gmail.com> writes:
>
>> attribute_groups are not supposed to change at runtime. So mark the
>> non-const structs as const.
>>
>> Arvind Yadav (10):
>>    [PATCH v2 01/10] net: cdc_ncm: constify attribute_group structures.
>>    [PATCH v2 02/10] net: can: at91_can: constify attribute_group structures.
>>    [PATCH v2 03/10] net: can: janz-ican3: constify attribute_group structures.
>>    [PATCH v2 04/10] wireless: ipw2200: constify attribute_group structures.
>>    [PATCH v2 05/10] wireless: ipw2100: constify attribute_group structures.
>>    [PATCH v2 06/10] wireless: iwlegacy: constify attribute_group structures.
>>    [PATCH v2 07/10] wireless: iwlegacy: Constify attribute_group structures.
>>    [PATCH v2 08/10] arcnet: com20020-pci: constify attribute_group structures.
>>    [PATCH v2 09/10] net: bonding: constify attribute_group structures.
>>    [PATCH v2 10/10] net: chelsio: cxgb3: constify attribute_group structures.
> Via which tree were you planning to push these? Is it ok if I take the
> wireless patches to my tree?
>
I have push these changes to linux-branch. you can take this to your branch.

~arvind
