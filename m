From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: Beginner's information on 2.6 implementation of networking
Date: Wed, 6 Apr 2005 13:34:28 -0500
Message-ID: <7bca1cb505040611343cd60c6c@mail.gmail.com>
References: <1112801850.4254023a192c5@webmail.purdue.edu>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chase Douglas <cndougla@purdue.edu>
In-Reply-To: <1112801850.4254023a192c5@webmail.purdue.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> present in the 2.6 kernel. Even if I could have a list of function calls from
> send to receive using the tcp/ip protocol, it would help a lot.

Have you looked at:
http://datatag.web.cern.ch/datatag/papers/tr-datatag-2004-1.pdf

Though this document is based on 2.4.20, it is similar to 2.6 and as
you go about looking at the code, the changes would be easy to
understand.

Hope that helps,

-- Asim
