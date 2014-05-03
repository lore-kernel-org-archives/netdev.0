From: Fernando Gont <fernando@gont.com.ar>
Subject: Fwd: RFC 7217 on A Method for Generating Semantically Opaque Interface
 Identifiers with IPv6 Stateless Address Autoconfiguration (SLAAC)
Date: Sat, 03 May 2014 05:09:32 -0500
Message-ID: <5364C05C.50504@gont.com.ar>
References: <20140430210539.E0D4318000D@rfc-editor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([37.72.100.182]:56789 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaECVCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 17:02:54 -0400
In-Reply-To: <20140430210539.E0D4318000D@rfc-editor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

FYI, RFC 7217 has been published:
<http://www.rfc-editor.org/rfc/rfc7217.txt>

It is meant to address the issues discussed in:
<http://tools.ietf.org/html/draft-ietf-opsec-ipv6-host-scanning> and
<http://tools.ietf.org/html/draft-ietf-6man-ipv6-address-generation-privacy>

Thanks!

Best regards,
Fernando




-------- Original Message --------Subject: RFC 7217 on A Method for
Generating Semantically Opaque Interface Identifiers with IPv6 Stateless
Address Autoconfiguration (SLAAC)
Date: Wed, 30 Apr 2014 14:05:39 -0700 (PDT)
From: rfc-editor@rfc-editor.org
Reply-To: ietf@ietf.org
To: ietf-announce@ietf.org, rfc-dist@rfc-editor.org
CC: drafts-update-ref@iana.org, ipv6@ietf.org, rfc-editor@rfc-editor.org

A new Request for Comments is now available in online RFC libraries.


        RFC 7217

        Title:      A Method for Generating Semantically
                    Opaque Interface Identifiers with IPv6 Stateless
                    Address Autoconfiguration (SLAAC)
        Author:     F. Gont
        Status:     Standards Track
        Stream:     IETF
        Date:       April 2014
        Mailbox:    fgont@si6networks.com
        Pages:      19
        Characters: 48497
        Updates/Obsoletes/SeeAlso:   None

        I-D Tag:    draft-ietf-6man-stable-privacy-addresses-17.txt

        URL:        http://www.rfc-editor.org/rfc/rfc7217.txt

This document specifies a method for generating IPv6 Interface
Identifiers to be used with IPv6 Stateless Address Autoconfiguration
(SLAAC), such that an IPv6 address configured using this method is
stable within each subnet, but the corresponding Interface Identifier
changes when the host moves from one network to another.  This method
is meant to be an alternative to generating Interface Identifiers
based on hardware addresses (e.g., IEEE LAN Media Access Control
(MAC) addresses), such that the benefits of stable addresses can be
achieved without sacrificing the security and privacy of users.  The
method specified in this document applies to all prefixes a host may
be employing, including link-local, global, and unique-local prefixes
(and their corresponding addresses).

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

For searching the RFC series, see http://www.rfc-editor.org/search
For downloading RFCs, see http://www.rfc-editor.org/rfc.html

Requests for special distribution should be addressed to either the
author of the RFC in question, or to rfc-editor@rfc-editor.org.  Unless
specifically noted otherwise on the RFC itself, all RFCs are for
unlimited distribution.


The RFC Editor Team
Association Management Solutions, LLC




-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1







-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
