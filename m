From: Francois Echantillac <francois.echantillac@ens-lyon.fr>
Subject: Re: [Fwd: Re: question: linux TCP/IP stack implementation]
Date: Fri, 10 Sep 2004 11:08:01 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094807281.41416ef16a42e@mouette.ens-lyon.fr>
References: <1094714541.15115.23.camel@poulenc.cs.sun.ac.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jab@cs.sun.ac.za
In-Reply-To: <1094714541.15115.23.camel@poulenc.cs.sun.ac.za>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Could you direct me to any good documentation on the implementation of
> the TCP/IP stack in the linux kernel.
> 
> I'm a Msc sudent of the University of Stellenbosch, South Africa.
> As an experiment I wat to replace the linux TCP implementation with a
> model checked version.

May i suggest you http://datatag.web.cern.ch/datatag/papers/tr-datatag-2004-1.pdf 

"In this technical report, we describe the structure and organization of the
networking code of Linux kernel 2.4.20. This release is the first of the 2.4
branch to support network interrupt mitigation via a mechanism known as NAPI. We
describe the main data structures, the sub-IP layer, the IP layer, and two
transport layers: TCP and UDP. This material is meant for people who are
familiar with operating systems but are not Linux kernel experts."

Included a lot of helpful figures.
Not sure it is what you are searching for.
Hope it will help.

Francois
