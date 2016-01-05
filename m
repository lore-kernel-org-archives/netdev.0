From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 0/4] Introduce mlx5 ethernet timestamping
Date: Tue, 5 Jan 2016 13:51:18 +0100
Message-ID: <20160105125118.GC5433@localhost.localdomain>
References: <1451393912-13736-1-git-send-email-saeedm@mellanox.com>
 <20160104.164703.651409223983114411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	eranbe@mellanox.com, talal@mellanox.com, majd@mellanox.com,
	achiad@mellanox.com, saeedm@dev.mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35686 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbcAEMvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 07:51:24 -0500
Received: by mail-wm0-f50.google.com with SMTP id f206so21718045wmf.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 04:51:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160104.164703.651409223983114411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 04:47:03PM -0500, David Miller wrote:
> Richard, please review this series.

It looks fine to me now, and I acked the timestamping/phc bits.

Thanks,
Richard
