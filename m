From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: Remove quotes of maintaners's names
Date: Thu, 27 Oct 2011 23:01:20 -0400 (EDT)
Message-ID: <20111027.230120.1348321590012576474.davem@davemloft.net>
References: <1319739381-5244-1-git-send-email-marcos.mage@gmail.com>
	<610B86C6-622E-4EFE-89DF-BF09BDB4D765@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcos.mage@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <610B86C6-622E-4EFE-89DF-BF09BDB4D765@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Date: Thu, 27 Oct 2011 14:35:54 -0700

> The reason these names are in quotes is because they need to be
> wrapped in quotes when used in a git patch (I.e. CC: "David
> S. Miller" <davem@davemloft.net>) because of the . in the friendly
> name.

That's correct, if a character such as "." appears in an email
header field it must be surrounded by double quotes, as per
SMTP rules.

VGER rejects any email where this rule is not followed properly.
