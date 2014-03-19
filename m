From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: openvswitch question
Date: Wed, 19 Mar 2014 15:14:06 +0530
Message-ID: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:56357 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758904AbaCSJoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 05:44:07 -0400
Received: by mail-yh0-f45.google.com with SMTP id a41so8231945yho.18
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 02:44:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,


openvswitch internal devices are not real nic. So some routine should
receive the packet  for this interface. Who is receiving packet for
this internal device.
I could find a question similar floating without any answer
http://comments.gmane.org/gmane.network.openvswitch.devel/19402

Any clue is really appreciated .

-Ratheesh
