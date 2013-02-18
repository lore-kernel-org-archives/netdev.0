From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]net: ehea module param description fix
Date: Mon, 18 Feb 2013 12:26:53 -0500 (EST)
Message-ID: <20130218.122653.2052167397005650003.davem@davemloft.net>
References: <511f24e7.iqc1+9PTu6xF8JTF%dyoung@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dyoung@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <511f24e7.iqc1+9PTu6xF8JTF%dyoung@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dyoung@redhat.com
Date: Sat, 16 Feb 2013 14:19:19 +0800

> In ehea.h the minimal entries is 2^7 - 1:
> #define EHEA_MIN_ENTRIES_QP  127
> 
> Thus change the module param description accordinglly
> 
> Signed-off-by: Dave Young <dyoung@redhat.com>

Applied.
