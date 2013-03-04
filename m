From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] CAIF: fix sparse warning for caif_usb
Date: Mon, 04 Mar 2013 14:15:36 -0500 (EST)
Message-ID: <20130304.141536.814115651801542145.davem@davemloft.net>
References: <1362380971-23007-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362380971-23007-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Mon,  4 Mar 2013 09:09:31 +0200

> This fixes the following sparse warning:
> net/caif/caif_usb.c:84:16: warning: symbol 'cfusbl_create' was not
> declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Applied.
