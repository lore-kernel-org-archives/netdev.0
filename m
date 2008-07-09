From: "\"G\"" <balajig81@gmail.com>
Subject: Implementing RSTP and MSTP in Linux Kernel
Date: Wed, 9 Jul 2008 21:30:16 +0530
Message-ID: <6dd1343e0807090900s3d905da1qe36cf21731fd3d4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:52153 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959AbYGIQAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 12:00:18 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1199638tic.23
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 09:00:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I am trying to extend the Linux bridging functionaltiy by adding
support for RSTP and MSTP in the linux kernel and i want to implement
it as a linux kernel module. I would like to know whats that i ve to
take care of while implementing this functionlality especially with
respect to locks etc. I ve gone through the basic bridging code so any
suggestions on this implementation would be of real good help.

Thanks for your time

Cheers,
Balaji
