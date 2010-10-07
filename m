From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: simplify conditional
Date: Thu, 07 Oct 2010 20:49:05 -0300
Message-ID: <4CAE5C71.50304@linux.vnet.ibm.com>
References: <20101008011450.0126ffc0@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101008011450.0126ffc0@absol.kitzblitz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2010 08:14 PM, Nicolas Kaiser wrote:
> Simplify: ((a&&  b) || (!a&&  !b)) =>  (a == b)
>
> Signed-off-by: Nicolas Kaiser<nikai@nikai.net>
Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>
