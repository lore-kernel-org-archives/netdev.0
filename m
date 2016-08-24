From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: wan-cosa: Use memdup_user() rather than duplicating its
 implementation
Date: Wed, 24 Aug 2016 18:14:13 +0200
Message-ID: <375bce2b-6c19-902e-65ce-cccaedd2184e@users.sourceforge.net>
References: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
 <20160824152154.GT10241@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Nicolas Palix <nicolas.palix@imag.fr>
To: Jan Kasprzak <kas@fi.muni.cz>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160824152154.GT10241@fi.muni.cz>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	What about the GFP_DMA attribute, which your patch deletes?
> The buffer in question has to be ISA DMA-able.

Thanks for your constructive feedback.

Would you be interested in using a variant of the function "memdup_…"
with which the corresponding memory allocation option can be preserved?

Regards,
Markus
