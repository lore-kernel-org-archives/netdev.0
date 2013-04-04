From: =?ISO-8859-1?Q?Marc_Mar=ED?= <5.markmb.5@gmail.com>
Subject: Fwd: New on this
Date: Thu, 4 Apr 2013 21:57:46 +0200
Message-ID: <CA+nFU8SrVn3+3aGzsmAy3xexiCQEMHS9a3AKc4p7H79toz9W7Q@mail.gmail.com>
References: <CA+nFU8RrfrYDwvRUCyjvu3BmxZFA98dozfHSn-hTPoMF4dOUBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:35417 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763740Ab3DDT5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 15:57:49 -0400
Received: by mail-qc0-f177.google.com with SMTP id u28so1320940qcs.36
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 12:57:48 -0700 (PDT)
In-Reply-To: <CA+nFU8RrfrYDwvRUCyjvu3BmxZFA98dozfHSn-hTPoMF4dOUBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some friends and I are trying to develop an application using AX.25
encoding, but not in standard situation.

It is intended to not use a TNC, and do everything by software, except
the transceiver itself, and by now, the transceiver can send data (not
AX.25, but plain data)

So now, we want to implement AX.25, so we can communicate with a
reciver which uses a TNC31. We've been looking a lot of documentation,
but we have not been able to determine what part of all the package
work will have to be done by hand.

We didn't configure AX25 yet, but we have the thought that what AX25
will return will be the data with the headers and CRC encapsulated in
KISS. Is that true?

So, we will have to do by hand the data whitening and scrambling
needed for the TNC?

Do you know any way to simplify all the process for a all-software transmission?

We are all a bit lost, and a bit of help would be very appreciated

Thank you in advance!
