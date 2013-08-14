From: Fernando Gont <fernando@gont.com.ar>
Subject: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with
 IPv6 Neighbor Discovery
Date: Wed, 14 Aug 2013 05:19:13 -0300
Message-ID: <520B3D81.9070506@gont.com.ar>
References: <20130813221321.AEA1AB1E003@rfc-editor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:37728 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759410Ab3HNIoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 04:44:25 -0400
In-Reply-To: <20130813221321.AEA1AB1E003@rfc-editor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

FYI. -- this is an important piece when it comes to First Hop (i.e.,
"local link") Security.

Cheers,
Fernando




-------- Original Message --------
Subject: RFC 6980 on Security Implications of IPv6 Fragmentation with
IPv6 Neighbor Discovery
Date: Tue, 13 Aug 2013 15:13:21 -0700 (PDT)
From: rfc-editor@rfc-editor.org
To: ietf-announce@ietf.org, rfc-dist@rfc-editor.org
CC: drafts-update-ref@iana.org, ipv6@ietf.org, rfc-editor@rfc-editor.org

A new Request for Comments is now available in online RFC libraries.


        RFC 6980

        Title:      Security Implications of IPv6 Fragmentation
                    with IPv6 Neighbor Discovery
        Author:     F. Gont
        Status:     Standards Track
        Stream:     IETF
        Date:       August 2013
        Mailbox:    fgont@si6networks.com
        Pages:      10
        Characters: 20850
        Updates:    RFC 3971, RFC 4861

        I-D Tag:    draft-ietf-6man-nd-extension-headers-05.txt

        URL:        http://www.rfc-editor.org/rfc/rfc6980.txt

This document analyzes the security implications of employing IPv6
fragmentation with Neighbor Discovery (ND) messages.  It updates RFC
4861 such that use of the IPv6 Fragmentation Header is forbidden in
all Neighbor Discovery messages, thus allowing for simple and
effective countermeasures for Neighbor Discovery attacks.  Finally,
it discusses the security implications of using IPv6 fragmentation
with SEcure Neighbor Discovery (SEND) and formally updates RFC 3971
to provide advice regarding how the aforementioned security
implications can be mitigated.

This document is a product of the IPv6 Maintenance Working Group of the
IETF.

This is now a Proposed Standard.

STANDARDS TRACK: This document specifies an Internet standards track
protocol for the Internet community,and requests discussion and suggestions
for improvements.  Please refer to the current edition of the Internet
Official Protocol Standards (STD 1) for the standardization state and
status of this protocol.  Distribution of this memo is unlimited.

This announcement is sent to the IETF-Announce and rfc-dist lists.
To subscribe or unsubscribe, see
  http://www.ietf.org/mailman/listinfo/ietf-announce
  http://mailman.rfc-editor.org/mailman/listinfo/rfc-dist

For searching the RFC series, see
http://www.rfc-editor.org/search/rfc_search.php
For downloading RFCs, see http://www.rfc-editor.org/rfc.html

Requests for special distribution should be addressed to either the
author of the RFC in question, or to rfc-editor@rfc-editor.org.  Unless
specifically noted otherwise on the RFC itself, all RFCs are for
unlimited distribution.


The RFC Editor Team
Association Management Solutions, LLC
--------------------------------------------------------------------
IETF IPv6 working group mailing list
ipv6@ietf.org
Administrative Requests: https://www.ietf.org/mailman/listinfo/ipv6
--------------------------------------------------------------------


-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1






-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
