From: "Martin Schwidefsky" <schwidefsky@googlemail.com>
Subject: Re: [patch 1/6] s390: minor claw driver fix
Date: Wed, 22 Mar 2006 16:42:14 +0100
Message-ID: <6e0cfd1d0603220742m80e553x461362297bf38e53@mail.gmail.com>
References: <20060322162821.6ebd9af6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751345AbWCVPmQ@vger.kernel.org>
To: "Frank Pavlic" <fpavlic@de.ibm.com>
In-Reply-To: <20060322162821.6ebd9af6@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/22/06, Frank Pavlic <fpavlic@de.ibm.com> wrote:
> [patch 1/6] s390: minor claw driver fix
>
> From: Frank Pavlic <fpavlic@de.ibm.com>
>
>         use CONFIG_ARCH_S390X instead of CONFIG_64BIT in function dumpit .

Nack. CONFIG_ARCH_S390X doesn't exists anymore. It has been replaced
by CONFIG_64BIT in 2.6.16.

--
blue skies,
  Martin
