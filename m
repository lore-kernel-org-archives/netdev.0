From: "K. Salah" <drsalah66@gmail.com>
Subject: NAPI quota and budget
Date: Sun, 4 Feb 2007 09:34:43 +0300
Message-ID: <b7dacee80702032234n5789e9b9n2dcf9239730d25b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:9491 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbXBDGeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 01:34:44 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1291413wxd
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 22:34:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello:

I am a new subscriber to netdev. Hope my first post is properly done.

I have a question about the quota per poll in NAPI.  Any idea how the
quota of 64 packets per poll per NIC was selected?  Why 64, not any
other number?  Is there science behind this number.

And the same goes for the budget of 300?

Was that done based on expermintation?

Thanks much in advance,


-- Salah
