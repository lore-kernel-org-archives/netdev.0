From: "Amar Mudrankit" <amar.mudrankit@qlogic.com>
Subject: Fwd: [ofa-general] FW: QLogic vNIC Kernel Submission
Date: Tue, 17 Jun 2008 22:48:52 +0530
Message-ID: <c8028d330806171018j7f129ddft3bee056e4be9b954@mail.gmail.com>
References: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com,
	"Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>,
	poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:46809 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092AbYFQRS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 13:18:56 -0400
Received: by ug-out-1314.google.com with SMTP id h2so612334ugf.16
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 10:18:52 -0700 (PDT)
In-Reply-To: <99863D2ED484D449811D97A4C44C9CBD7C50F7@EPEXCH2.qlogic.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
From: John Russo <john.russo@qlogic.com>
Date: Tue, Jun 17, 2008 at 6:36 PM
Subject: [ofa-general] FW: QLogic vNIC Kernel Submission
To: general@lists.openfabrics.org


It looks as if my original email was "scrubbed" before it made the
mailing list so I am resending it...

QLogic has been attempting to submit our virtual NIC (vNIC) driver to
the Linux kernel for several months.  We have made changes to the code
based on the feedback we have received over four rounds of
submissions. Among the feedback we received during this process was a
request to alter our code to use a single value per file for
configuration of our driver through sysfs interface.  After spending
much time and effort to complete this change to our design we
re-submitted the driver only to receive a response suggesting that we
change once again from this interface to a different API interface
called rtnl_link.  Needless to say I am very frustrated with this
process. This new API interface would require substantial changes to
our code.

QLogic has met the initial request to move to a single valued sysfs
interface and I would hope that this new request will be waived and
will not be a roadblock to inclusion of our driver to the kernel.

_______________________________________________
general mailing list
general@lists.openfabrics.org
http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general

To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
