From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCHv2] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Wed, 5 Oct 2016 23:54:50 +0200
Message-ID: <726EB74C-73CD-49A9-891A-9E74E9382E56@holtmann.org>
References: <20161003085640.GA8130@amd> <20161005205142.GA26186@amd>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161005205142.GA26186@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

> bluetooth.h is not part of user API, so __ variants are not neccessary
> here.
> 
> Signed-off-by: Pavel Machek <pavel@ucw.cz>
> 
> ---
> v2: not touching stuff that Marcel does not want touched, as it will
> become API later.

patch has been applied to bluetooth-next tree.

Regards

Marcel
