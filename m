From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Mon, 14 Mar 2011 14:04:09 +0800
Message-ID: <4D7DAFD9.8070705@redhat.com>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com> <20110308212405.GX11864@gospo.rdu.redhat.com> <4D7773E3.5050708@redhat.com> <20110311143557.GY11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110311143557.GY11864@gospo.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B403=E6=9C=8811=E6=97=A5 22:35, Andy Gospodarek =E5=
=86=99=E9=81=93:
>
> I'm happy to submit the patch if it works in your environment.
>
> I do not think anyone likes un-tested patches.
>

Just test it by hands, it works, you can add

Tested-by: WANG Cong <amwang@redhat.com>

Thanks!
