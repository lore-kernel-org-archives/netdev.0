From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: dsa: b53: constify b53_io_ops structures
Date: Tue, 9 Aug 2016 10:39:40 -0700
Message-ID: <ef2b8dcb-1a30-7de3-0713-8e8b46d89c1c@gmail.com>
References: <1470762585-2670-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1470762585-2670-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2016 10:09 AM, Julia Lawall wrote:
> The b53_io_ops structures are never modified, so declare them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
