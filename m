From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [BUG] vmxnet3: random freeze regression
Date: Wed, 22 Feb 2017 09:38:10 -0800
Message-ID: <20170222093810.6e0c4033@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33012 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932223AbdBVRiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:38:54 -0500
Received: by mail-pf0-f174.google.com with SMTP id 2so56658pfz.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 09:38:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I get the bugzilla reports for networking, and I see several reports
of vmxnet3 hanging with 4.8 and later kernels.

Is this a know issue?

https://bugzilla.kernel.org/show_bug.cgi?id=191201
