From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] Any implementation of NETPOLL for bonding?
Date: Wed, 24 Jun 2009 16:32:35 -0400
Message-ID: <bdfc5d6e0906241332k6c4c89a7s844526a009a30d98@mail.gmail.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
	 <20090615230907.GA8515@gospo.rdu.redhat.com>
	 <1245165201.11148.244.camel@psmith-ubeta.netezza.com>
	 <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
	 <4A428AB0.8080400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paul@mad-scientist.us, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Bert Barbe <bert.barbe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:27061 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbZFXUcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 16:32:33 -0400
Received: by qw-out-2122.google.com with SMTP id 9so323105qwb.37
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 13:32:35 -0700 (PDT)
In-Reply-To: <4A428AB0.8080400@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 4:21 PM, Bert Barbe<bert.barbe@oracle.com> wrote:
> Hi,
>
> We also ported netpoll to bonding for EL5 in kernel 2.6.18-92.1.22.0.1.el5
>
> You can see the src rpm with the patch here:
> http://oss.oracle.com/el5/SRPMS-updates/kernel-2.6.18-92.1.22.0.1.el5.src.rpm
>
> Regards,
> Bert
>

There certainly are some older bonding+netpoll patches lying around if
you have a kernel based on something as old as RHEL5 (2.6.18-based).

Like this one, for example:

http://people.redhat.com/agospoda/rhel5/0075-bonding-add-netconsole-support.patch
