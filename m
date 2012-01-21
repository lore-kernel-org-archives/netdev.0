From: Reuben Hawkins <reubenhwk@gmail.com>
Subject: radvd-1.8.4 release
Date: Sat, 21 Jan 2012 00:37:25 -0800
Message-ID: <CAD_8n+SgFEK++3xH0Av2_FOC4FczKKSrhK0nYOzwTYcFB=h5xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: radvd Development Discussion <radvd-devel-l@litech.org>,
	radvd-announce-l@litech.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47879 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab2AUIh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 03:37:28 -0500
Received: by werb13 with SMTP id b13so1015883wer.19
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2012 00:37:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Radvd 1.8.4 has been release.  This release is a minor update which
includes changes for these items:

* Fixes in privsep on linux
* privsep is now the default and only code path
* added --nodaemon option

Please get the latest here: http://www.litech.org/radvd

Thanks,
Reuben
