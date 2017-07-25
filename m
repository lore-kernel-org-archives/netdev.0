From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 00/10] Constify attribute_group structures
Date: Tue, 25 Jul 2017 15:55:40 +0300
Message-ID: <87fudkiskz.fsf@codeaurora.org>
References: <1499758370-24871-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: sgruszka@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499758370-24871-1-git-send-email-arvind.yadav.cs@gmail.com>
        (Arvind Yadav's message of "Tue, 11 Jul 2017 13:02:48 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> writes:

> attribute_groups are not supposed to change at runtime. So mark the
> non-const structs as const.
>
> Arvind Yadav (10):
>   [PATCH v2 01/10] net: cdc_ncm: constify attribute_group structures.
>   [PATCH v2 02/10] net: can: at91_can: constify attribute_group structures.
>   [PATCH v2 03/10] net: can: janz-ican3: constify attribute_group structures.
>   [PATCH v2 04/10] wireless: ipw2200: constify attribute_group structures.
>   [PATCH v2 05/10] wireless: ipw2100: constify attribute_group structures.
>   [PATCH v2 06/10] wireless: iwlegacy: constify attribute_group structures.
>   [PATCH v2 07/10] wireless: iwlegacy: Constify attribute_group structures.
>   [PATCH v2 08/10] arcnet: com20020-pci: constify attribute_group structures.
>   [PATCH v2 09/10] net: bonding: constify attribute_group structures.
>   [PATCH v2 10/10] net: chelsio: cxgb3: constify attribute_group structures.

Via which tree were you planning to push these? Is it ok if I take the
wireless patches to my tree?

-- 
Kalle Valo
