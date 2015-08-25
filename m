From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] /net/ethernet/3com/3c59x.c:Fixed coding style errors
 and warnings.
Date: Tue, 25 Aug 2015 11:20:38 -0700 (PDT)
Message-ID: <20150825.112038.37235422253496120.davem@davemloft.net>
References: <1440170825-4370-1-git-send-email-rednivaralat@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rednivaralat@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440170825-4370-1-git-send-email-rednivaralat@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ravinder Atla <rednivaralat@gmail.com>
Date: Fri, 21 Aug 2015 20:57:05 +0530

> Checks are also cleared
> Signed-off-by: Ravinder Atla <rednivaralat@gmail.com>

Your subject should read "3c59x: Fixed coding..." rather than what you used.

Also, your patch adds new coding style errors:

[davem@localhost net-next]$ git am --signoff net-ethernet-3com-3c59x.c-Fixed-coding-style-errors-and-warnings..patch
Applying: 3c59x: Fixed coding style errors and warnings.
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:81: trailing whitespace.
	 PCI_USES_MASTER, IS_TORNADO | HAS_NWAY | EEPROM_8BIT | HAS_CB_FNS | 
warning: 1 line adds whitespace errors.
