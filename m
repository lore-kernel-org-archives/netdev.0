From: nickcooper-zhangtonghao <nic.tongh@gmail.com>
Subject: ovs internal_dev mtu
Date: Mon, 19 Dec 2016 16:59:44 +0800
Message-ID: <E0899132-14F7-45F9-8F02-94421B595D4E@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33087 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932235AbcLSJAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 04:00:50 -0500
Received: by mail-pf0-f194.google.com with SMTP id 144so7270118pfv.0
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 01:00:49 -0800 (PST)
Received: from [127.0.0.1] (ec2-54-187-133-126.us-west-2.compute.amazonaws.com. [54.187.133.126])
        by smtp.gmail.com with ESMTPSA id y15sm29649463pgc.43.2016.12.19.01.00.47
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 01:00:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upstream net-next has removed the =E2=80=9Cinternal_dev_change_mtu=E2=80=
=9D.=20
It will be ok for ovs(e.g. mtu_request) ? I think that code should
be keep. Can you provide more information =EF=BC=9F=
