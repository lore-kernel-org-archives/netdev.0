From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: patch prism54usb: add set_bssid_filter
Date: Mon, 24 Apr 2006 16:57:42 -0400
Message-ID: <20060424205733.GD21761@tuxdriver.com>
References: <20060331233159.a8893328.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jean-baptiste.note@m4x.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:33294 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751267AbWDXU56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 16:57:58 -0400
To: Pete Zaitcev <zaitcev@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060331233159.a8893328.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2006 at 11:31:59PM -0800, Pete Zaitcev wrote:
> Implement proper set_bssid_filter. If filters are not set, firmware receives
> management frames only (instead of everything), so this is necessary.

Merged to master branch of wireless-2.6 tree.

Thanks!
-- 
John W. Linville
linville@tuxdriver.com
