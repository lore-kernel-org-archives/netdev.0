From: "Brown, Len" <len.brown@intel.com>
Subject: RE: oops in current -git
Date: Tue, 11 Jul 2006 11:55:10 -0400
Message-ID: <CFF307C98FEABE47A452B27C06B85BB6F3116F@hdsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37726 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750758AbWGKPzh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 11:55:37 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>,
	"Netdev List" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

try latest -mm, latest ACPI patch, or
try CONFIG_ACPI_BATTERY=n

-Len
