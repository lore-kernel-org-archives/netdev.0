From: Francisco Cuesta <ndarkness@gmail.com>
Subject: Fwd: IW channels list question
Date: Mon, 18 Mar 2013 13:48:43 +0100
Message-ID: <CANMvdA-b7LA7ndPcTGOpNr-LofAQdO0C_F8+ph2SWxbu_xb2Kg@mail.gmail.com>
References: <CANMvdA-oX331PYALksgwWRPycHs+rL6Kmk4CVXG3UsBpF=qKnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:56787 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab3CRMsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:48:43 -0400
Received: by mail-qe0-f41.google.com with SMTP id 6so3327025qeb.28
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 05:48:43 -0700 (PDT)
In-Reply-To: <CANMvdA-oX331PYALksgwWRPycHs+rL6Kmk4CVXG3UsBpF=qKnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello iw developers,


I would like to ask a question related to the command iw list. The
channels shown with this command where are they taken from? I mean,
does iw call the drivers' API to see which frequencies it can provide?

I ask this in that if I change the regulatory domain to Japan for
instance, I cannot see the 4.9GHz channels with iw list, does it mean
that the driver doesn't support such a channels or that I maybe have
to modify iw list source in order to make them show up?

Thanks in advance,

REgards,

Francisco
