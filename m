From: "pupilla@libero.it" <pupilla@libero.it>
Subject: routing policy based on u32 classifier
Date: Wed, 1 Feb 2017 11:34:04 +0100 (CET)
Message-ID: <1326989143.11056951485945244609.JavaMail.httpd@webmail-35.iol.local>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-35.italiaonline.it ([212.48.25.163]:47597 "EHLO libero.it"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751202AbdBAKmR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 05:42:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

Kindly I would like to ask if there is a way to do routing
policy based on u32 classifier without fwmark/netfilter.
I have read doc/tc-filters and doc/actions/actions-general
from iproute2-4.9.0 package but I am not able to find any
actions doing this kind of job: the only way is to mark
packets with netfilter.

Any response are welcome

TIA

Marco
