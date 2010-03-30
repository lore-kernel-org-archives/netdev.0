From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 2/2] ath: fix code readability in regd.c
Date: Tue, 30 Mar 2010 09:56:45 -0700
Message-ID: <20100330165645.GB25095@tux>
References: <ath/regd.c>
 <1269963873-2070-1-git-send-email-luisbg@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Luis de Bethencourt <luisbg@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269963873-2070-1-git-send-email-luisbg@ubuntu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2010 at 08:44:33AM -0700, Luis de Bethencourt wrote:
> This is a patch to the ath/regd.c file that fixes two code
> readability issues. A space between to separate two defines
> and the indentation inside the ath_redg_is_eeprom_valid
> function.

Acked-by: Luis R. Rodriguez <lrodriguez@atheros.com>

You can drop netdev and linux-kernel from future linux-wireless e-mails
like this one.

  Luis
