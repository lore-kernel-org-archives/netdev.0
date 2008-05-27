From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v2 12/13] QLogic VNIC: Driver Kconfig and Makefile.
Date: Tue, 27 May 2008 11:53:42 +0530
Message-ID: <71d336490805262323qd876161ue86f98dbc8499ad6@mail.gmail.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	 <20080519103730.12355.14730.stgit@localhost.localdomain>
	 <adamyme57ir.fsf@cisco.com>
	 <71d336490805260037y4c45abd5lccd5dbadebd84eb8@mail.gmail.com>
	 <adaod6s4u1a.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:65247 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbYE0GXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 02:23:46 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1608715tic.23
        for <netdev@vger.kernel.org>; Mon, 26 May 2008 23:23:43 -0700 (PDT)
In-Reply-To: <adaod6s4u1a.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland,

On Tue, May 27, 2008 at 3:17 AM, Roland Dreier <rdreier@cisco.com> wrote:

> OK, I looked at the code.  Is there any point to having
> CONFIG_INFINIBAND_QLGC_VNIC_DEBUG at all??  Is anyone going to care
> about having __FILE__ and __LINE__ included in the output and want to
> set this option to 'n'?

Makes sense. We will get rid of this CONFIG option. Apart from this
are there any other changes you
would like to see in the patch series ?

Regards,
Ram
