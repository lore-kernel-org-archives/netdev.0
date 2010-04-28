From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Wed, 28 Apr 2010 07:47:07 +0200
Message-ID: <20100428054706.GA4516@riccoc20.at.omicron.at>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:17055 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab0D1FrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 01:47:12 -0400
Received: by fg-out-1718.google.com with SMTP id 19so3085092fgg.1
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 22:47:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BD70EC9.7080004@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 06:20:25PM +0200, Wolfgang Grandegger wrote:
> Do you have also a patch adding support for hardware timestamping to ptpd?

Yes, I do:

   https://sourceforge.net/tracker/index.php?func=detail&aid=2992847&group_id=139814&atid=744634

I should have mentioned, you also need the gianfar HW time stamping
patches, recently posted to netdev by Manfred Rudigier.

Enjoy,

Richard
