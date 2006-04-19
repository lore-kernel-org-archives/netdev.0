From: "Ian McDonald" <imcdnzl@gmail.com>
Subject: Re: [offlist] Re: [LARTC] how to do probabilistic packet loss in kernel?
Date: Thu, 20 Apr 2006 07:19:12 +1200
Message-ID: <cbec11ac0604191219q10bb9334uf64494dc2793b5c4@mail.gmail.com>
References: <4902.128.2.140.224.1145227461.squirrel@128.2.140.224>
	 <Pine.LNX.4.61.0604161909310.6147@virgule.wonderfrog.net>
	 <4442E319.50309@cmu.edu>
	 <Pine.LNX.4.61.0604161933210.6147@virgule.wonderfrog.net>
	 <2959.128.237.238.138.1145242426.squirrel@128.237.238.138>
	 <Pine.LNX.4.61.0604190741260.6853@virgule.wonderfrog.net>
	 <44464167.40702@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Martin A. Brown" <martin@linux-ip.net>, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.207]:46392 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751192AbWDSTTU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 15:19:20 -0400
Received: by nz-out-0102.google.com with SMTP id 14so990890nzn
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2006 12:19:20 -0700 (PDT)
To: "George Nychis" <gnychis@cmu.edu>
In-Reply-To: <44464167.40702@cmu.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/06, George Nychis <gnychis@cmu.edu> wrote:
> Hey Martin,
>
> I was able to do it with netem and its working great now.
>
> I've actually moved on to another challenge, I would like to drop
> packets at the hardware level such as to see rate control.
>
Have a look at:
http://linux-net.osdl.org/index.php/Netem#Rate_control

Works well for me...

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
