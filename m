From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: gigabit trouble
Date: Tue, 3 Aug 2004 09:48:42 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040803094842.B4911@electric-eye.fr.zoreil.com>
References: <20040729210401.A32456@electric-eye.fr.zoreil.com> <b71082d80407291541f9d6f93@mail.gmail.com> <b71082d804073008157cf1d6c0@mail.gmail.com> <20040730205412.A15669@electric-eye.fr.zoreil.com> <b71082d804073014037bc5dd5a@mail.gmail.com> <20040730234120.A15536@electric-eye.fr.zoreil.com> <b71082d804073112512bbd82e2@mail.gmail.com> <20040731231836.A31121@electric-eye.fr.zoreil.com> <b71082d804080112031621e041@mail.gmail.com> <b71082d804080219476103bd47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265134AbUHCHvs@vger.kernel.org>
To: Bart Alewijnse <scarfboy@gmail.com>
Content-Disposition: inline
In-Reply-To: <b71082d804080219476103bd47@mail.gmail.com>; from scarfboy@gmail.com on Tue, Aug 03, 2004 at 04:47:43AM +0200
List-Id: netdev.vger.kernel.org

Bart Alewijnse <scarfboy@gmail.com> :
[...]
> The panic looks a lot like the last one; same kernel (napi still
> enabled for the 8169). Image attached.

The irq rate are strangely high for a napi version of the r8169 driver.

Can you describe your test commands so that I reproduce these here ?

--
Ueimor
