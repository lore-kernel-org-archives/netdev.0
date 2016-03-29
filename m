From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 1/2] net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read,write}
Date: Tue, 29 Mar 2016 12:26:37 -0400
Message-ID: <87d1qdfdxe.fsf@ketchup.mtl.sfl>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dennis@ausil.us, pbrobinson@gmail.com,
	Patrick Uiterwijk <patrick@puiterwijk.org>
To: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38071 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbcC2Q0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 12:26:40 -0400
In-Reply-To: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Uiterwijk <patrick@puiterwijk.org> writes:

> Add versions of the phy_page_read and _write functions to
> be used in a context where the SMI mutex is held.
>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,
Vivien
