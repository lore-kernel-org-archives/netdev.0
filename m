From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: 3.10 stable request: iwlwifi: add new 7260 and 3160 series device IDs
Date: Sat, 12 Oct 2013 00:26:30 +0200
Message-ID: <87mwmftpex.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oren Givon <oren.givon@intel.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54669 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807Ab3JKW0h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 18:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

could you please add this commit to your 3.10 stable queue?

commit 93fc64114b994f9ef6901697f9b0de00762680e9
Author: Oren Givon <oren.givon@intel.com>
Date:   Tue Apr 23 18:19:11 2013 +0300

    iwlwifi: add new 7260 and 3160 series device IDs
   =20
    Add new device IDs and configurations to support
    all the devices.
   =20
    Signed-off-by: Oren Givon <oren.givon@intel.com>
    Signed-off-by: Johannes Berg <johannes.berg@intel.com>



I just installed Debian testing on a Sony Vaio Pro and that was a bit
more hassle than necessary due to this patch missing in their 3.10.11
based kernel...

The patch applies cleanly on top of v3.10.15, and only add new device
IDs, so it should be a clear stable candidate.



Thanks,
Bj=C3=B8rn
